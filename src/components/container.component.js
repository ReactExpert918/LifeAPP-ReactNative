import React from "react";
import { StyleSheet, SafeAreaView } from "react-native";

const contain = StyleSheet.create({
    container: {
        flex: 1,
    }
})

export const ContainerComponent = ({ children }) => {
    return(
        <SafeAreaView style={contain.container} >
            {children}
        </SafeAreaView>
    )
}