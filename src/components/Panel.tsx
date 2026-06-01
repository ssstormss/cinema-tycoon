import React from "react";
import { Modal, Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import { colors } from "../theme";

interface PanelProps {
  title: string;
  subtitle: string;
  children: React.ReactNode;
  onClose: () => void;
}

export function Panel({ title, subtitle, children, onClose }: PanelProps) {
  return (
    <Modal visible transparent animationType="slide" onRequestClose={onClose}>
      <View style={styles.scrim}>
        <View style={styles.panel}>
          <View style={styles.header}>
            <View>
              <Text style={styles.title}>{title}</Text>
              <Text style={styles.subtitle}>{subtitle}</Text>
            </View>
            <Pressable style={styles.close} onPress={onClose}>
              <Text style={styles.closeText}>×</Text>
            </Pressable>
          </View>
          <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={styles.content}>
            {children}
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

export function Card({ children }: { children: React.ReactNode }) {
  return <View style={styles.card}>{children}</View>;
}

export function BuyButton({ label, disabled, onPress }: { label: string; disabled: boolean; onPress: () => void }) {
  return (
    <Pressable
      disabled={disabled}
      onPress={onPress}
      style={({ pressed }) => [styles.buy, disabled && styles.disabled, pressed && !disabled && styles.pressed]}
    >
      <Text style={[styles.buyText, disabled && styles.disabledText]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  scrim: {
    flex: 1,
    justifyContent: "flex-end",
    backgroundColor: "rgba(0,0,0,0.58)"
  },
  panel: {
    maxHeight: "82%",
    paddingTop: 16,
    paddingHorizontal: 16,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    backgroundColor: colors.panel,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.09)"
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 14
  },
  title: {
    color: colors.text,
    fontSize: 24,
    fontWeight: "900"
  },
  subtitle: {
    color: colors.muted,
    fontSize: 12,
    marginTop: 3
  },
  close: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: colors.panel2,
    alignItems: "center",
    justifyContent: "center"
  },
  closeText: {
    color: colors.text,
    fontSize: 30,
    lineHeight: 32,
    fontWeight: "300"
  },
  content: {
    paddingBottom: 32,
    gap: 12
  },
  card: {
    padding: 14,
    borderRadius: 18,
    backgroundColor: colors.panel2,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.08)",
    shadowColor: colors.shadow,
    shadowOpacity: 0.35,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 10 },
    elevation: 8
  },
  buy: {
    paddingHorizontal: 14,
    paddingVertical: 11,
    borderRadius: 14,
    backgroundColor: colors.gold,
    alignItems: "center",
    minWidth: 116
  },
  disabled: {
    backgroundColor: "rgba(255,255,255,0.09)"
  },
  pressed: {
    transform: [{ scale: 0.97 }]
  },
  buyText: {
    color: "#1b1023",
    fontWeight: "900",
    fontSize: 13
  },
  disabledText: {
    color: colors.dim
  }
});

