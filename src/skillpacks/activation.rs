//! Skill activation and lifecycle management.

use super::{parser::parse_skill_md, SkillIndex, SkillPack};
use anyhow::{anyhow, Result};
use std::collections::{HashMap, HashSet};

/// Result of skill activation
#[derive(Debug)]
pub struct SkillActivation {
    pub name: String,
    pub description: String,
    pub allowed_tools: Option<Vec<String>>,
}

/// Manages the set of active skills
#[derive(Debug, Default)]
pub struct ActiveSkills {
    active: HashMap<String, SkillPack>,
}

impl ActiveSkills {
    pub fn new() -> Self {
        Self::default()
    }

    /// Activate a skill by name
    pub fn activate(&mut self, name: &str, index: &SkillIndex) -> Result<SkillActivation> {
        // Check if already active
        if self.active.contains_key(name) {
            return Err(anyhow!("Skill '{}' is already active", name));
        }

        // Find in index
        let meta = index
            .get(name)
            .ok_or_else(|| anyhow!("Skill '{}' not found", name))?;

        // Load full SKILL.md
        let pack = parse_skill_md(&meta.path)?;

        let activation = SkillActivation {
            name: pack.name.clone(),
            description: pack.description.clone(),
            allowed_tools: pack.allowed_tools.clone(),
        };

        self.active.insert(pack.name.clone(), pack);

        Ok(activation)
    }

    /// Deactivate a skill
    pub fn deactivate(&mut self, name: &str) -> Result<()> {
        if self.active.remove(name).is_none() {
            return Err(anyhow!("Skill '{}' is not active", name));
        }
        Ok(())
    }

    /// Get list of active skill names
    pub fn list(&self) -> Vec<&str> {
        self.active.keys().map(|s| s.as_str()).collect()
    }

    /// Check if any skills are active
    pub fn is_empty(&self) -> bool {
        self.active.is_empty()
    }

    /// Get active skill by name
    pub fn get(&self, name: &str) -> Option<&SkillPack> {
        self.active.get(name)
    }

    /// Compute effective allowed tools (intersection of all active skills)
    /// Returns None if no restrictions (no active skills specify allowed-tools)
    pub fn effective_allowed_tools(&self) -> Option<Vec<String>> {
        let restrictions: Vec<&Vec<String>> = self
            .active
            .values()
            .filter_map(|p| p.allowed_tools.as_ref())
            .collect();

        // Start with first set, intersect with rest
        let first = restrictions.first()?;
        let mut effective: HashSet<&String> = first.iter().collect();

        for r in restrictions.iter().skip(1) {
            let other: HashSet<&String> = r.iter().collect();
            effective = effective.intersection(&other).cloned().collect();
        }

        Some(effective.into_iter().cloned().collect())
    }

    /// Format active skills for conversation injection
    pub fn format_for_conversation(&self) -> String {
        let mut parts = Vec::new();

        for pack in self.active.values() {
            parts.push(format!(
                "## Active Skill: {}\n\n{}",
                pack.name, pack.instructions
            ));
        }

        parts.join("\n\n---\n\n")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_effective_allowed_tools_intersection() {
        // Simulate two skill packs with overlapping allowed_tools
        let mut active = ActiveSkills::new();

        // Manually insert packs for testing
        active.active.insert(
            "skill1".to_string(),
            SkillPack {
                name: "skill1".to_string(),
                description: "Skill 1".to_string(),
                allowed_tools: Some(vec![
                    "Read".to_string(),
                    "Grep".to_string(),
                    "Glob".to_string(),
                ]),
                instructions: "".to_string(),
                root_path: std::path::PathBuf::new(),
            },
        );

        active.active.insert(
            "skill2".to_string(),
            SkillPack {
                name: "skill2".to_string(),
                description: "Skill 2".to_string(),
                allowed_tools: Some(vec!["Bash".to_string(), "Read".to_string()]),
                instructions: "".to_string(),
                root_path: std::path::PathBuf::new(),
            },
        );

        let effective = active.effective_allowed_tools().unwrap();
        assert_eq!(effective.len(), 1);
        assert!(effective.contains(&"Read".to_string()));
    }
}
