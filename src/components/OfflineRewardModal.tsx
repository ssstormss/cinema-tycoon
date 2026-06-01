import React from "react";
import { Modal, Pressable, StyleSheet, Text, View } from "react-native";
import { colors } from "../theme";
import { shortMoney } from "../utils/economy";

interface OfflineRewardModalProps {
  amount: number;
  visible: boolean;
  onClose: () => void;
}

export function OfflineRewardModal({ amount, visible, onClose }: OfflineRewardModalProps) {
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View style={styles.scrim}>
        <View style={styles.card}>
          <Text style={styles.icon}>🌙</Text>
          <Text style={styles.title}>Offline Earnings</Text>
          <Text style={styles.text}>Dein Kino hat weiter Tickets und Snacks verkauft.</Text>
          <Text style={styles.amount}>{shortMoney(amount)}</Text>
          <Pressable style={styles.button} onPress={onClose}>
            <Text style={styles.buttonText}>Collect</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  scrim: {
    flex: 1,
    backgroundColor: "rgba(0,0,0,0.72)",
    alignItems: "center",
    justifyContent: "center",
    padding: 24
  },
  card: {
    width: "100%",
    maxWidth: 360,
    padding: 24,
    borderRadius: 28,
    backgroundColor: colors.panel,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.12)",
    alignItems: "center"
  },
  icon: {
    fontSize: 42
  },
  title: {
    color: colors.text,
    fontSize: 24,
    fontWeight: "900",
    marginTop: 10
  },
  text: {
    color: colors.muted,
    textAlign: "center",
    lineHeight: 20,
    marginTop: 8
  },
  amount: {
    color: colors.gold,
    fontSize: 38,
    fontWeight: "900",
    marginVertical: 18
  },
  button: {
    backgroundColor: colors.gold,
    borderRadius: 16,
    paddingHorizontal: 28,
    paddingVertical: 13
  },
  buttonText: {
    color: "#1b1023",
    fontWeight: "900",
    fontSize: 15
  }
});

