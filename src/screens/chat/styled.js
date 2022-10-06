import { View, StyleSheet, ScrollView, Text } from "react-native";
import { colors } from "../../assets/colors";

export const chatStyle = StyleSheet.create({
    divider: {
        backgroundColor: colors.ui.divider,
        width: "100%",
        height: 1
    },
    mainContainer: {
        flex: 1,
        backgroundColor: colors.ui.primary,
    },
    topContainer: {
        backgroundColor: colors.ui.primary,
        width: '100%',
        height: 60,
        flexDirection: 'row',
        padding: 10 
    },
    container: {
        flex: 1,
        backgroundColor: colors.ui.white
    },
    scrollContainer: {
        flex: 1,
        backgroundColor: colors.ui.white
    },
})