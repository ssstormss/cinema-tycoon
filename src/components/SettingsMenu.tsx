import React from "react";
import { Alert, StyleSheet, Text } from "react-native";
import { useGameStore } from "../store/gameStore";
import { colors } from "../theme";
import { BuyButton, Card, Panel } from "./Panel";

export function SettingsMenu({ onClose }: { onClose: () => void }) {
  const resetGame = useGameStore((state) => state.resetGame);

  return (
    <Panel title="Settings" subtitle="Lokaler Spielstand und Sicherheit." onClose={onClose}>
      <Card>
        <Text style={styles.title}>Autosave aktiv</Text>
        <Text style={styles.text}>
          Dein Fortschritt wird lokal mit AsyncStorage gespeichert. Offline-Einnahmen werden beim Start fuer maximal acht Stunden berechnet.
        </Text>
      </Card>
      <Card>
        <Text style={styles.title}>Spielstand</Text>
        <Text style={styles.text}>Setzt Geld, Upgrades, Gebaeude, Mitarbeiter und Missionen zurueck.</Text>
        <BuyButton
          label="Reset game"
          disabled={false}
          onPress={() =>
            Alert.alert("Spielstand loeschen?", "Das kann nicht rueckgaengig gemacht werden.", [
              { text: "Abbrechen", style: "cancel" },
              { text: "Loeschen", style: "destructive", onPress: resetGame }
            ])
          }
        />
      </Card>
    </Panel>
  );
}

const styles = StyleSheet.create({
  title: {
    color: colors.text,
    fontSize: 16,
    fontWeight: "900",
    marginBottom: 6
  },
  text: {
    color: colors.muted,
    fontSize: 13,
    lineHeight: 19,
    marginBottom: 12
  }
});

