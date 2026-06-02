import React from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import type { PanelId } from "../types";
import { colors } from "../theme";

const items: Array<{ id: PanelId; label: string; icon: string }> = [
  { id: "build", label: "Build", icon: "＋" },
  { id: "upgrades", label: "Upgrade", icon: "↟" },
  { id: "missions", label: "Missions", icon: "✓" },
  { id: "stats", label: "Stats", icon: "▣" },
  { id: "settings", label: "Settings", icon: "⚙" }
];

interface BottomNavProps {
  activePanel: PanelId | null;
  onSelect: (panel: PanelId) => void;
}

export function BottomNav({ activePanel, onSelect }: BottomNavProps) {
  return (
    <View style={styles.wrap}>
      {items.map((item) => {
        const active = activePanel === item.id;
        return (
          <Pressable
            key={item.id}
            style={({ pressed }) => [styles.button, active && styles.buttonActive, pressed && styles.pressed]}
            onPress={() => onSelect(item.id)}
          >
            <Text style={[styles.icon, active && styles.iconActive]}>{item.icon}</Text>
            <Text style={[styles.label, active && styles.labelActive]}>{item.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: "row",
    gap: 8,
    paddingHorizontal: 12,
    paddingTop: 10,
    paddingBottom: 12,
    backgroundColor: "rgba(9,8,20,0.98)",
    borderTopColor: "rgba(255,255,255,0.09)",
    borderTopWidth: 1
  },
  button: {
    flex: 1,
    minHeight: 58,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 16,
    backgroundColor: colors.panel,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)"
  },
  buttonActive: {
    backgroundColor: "#2a1840",
    borderColor: colors.pink
  },
  pressed: {
    transform: [{ scale: 0.97 }]
  },
  icon: {
    color: colors.muted,
    fontSize: 20,
    fontWeight: "900"
  },
  iconActive: {
    color: colors.gold
  },
  label: {
    color: colors.muted,
    fontSize: 10,
    fontWeight: "800",
    marginTop: 2
  },
  labelActive: {
    color: colors.text
  }
});

