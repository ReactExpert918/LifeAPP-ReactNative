import React from "react";
import { StyleSheet, View } from "react-native";
import { colors } from "../assets/colors";

const header = StyleSheet.create({
    container: {
        height: 60,
        width: '100%',
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "row",
        backgroundColor: colors.ui.primary
    },
})

export const HeaderComponent = ({ children }) => {
  return (
    <View style={header.container} >
      {children}
    </View>
  )
};
