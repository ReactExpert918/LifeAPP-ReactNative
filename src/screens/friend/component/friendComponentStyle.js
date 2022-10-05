import { StyleSheet, View } from "react-native";
import { colors } from "../../assets/colors";

export const sectionComponentStyle = StyleSheet.create({
    container: {
        height: 50,
        width: '100%',
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'row',
        padding: 10
    },
    textContainer: {
        flex: 1,
        alignItems: 'flex-start',
        justifyContent: 'center',
    }
})

export const personComponentStyle = StyleSheet.create({
    container: {
        height: 60,
        width: '100%',
        alignItems: 'center',
        justifyContent: 'flex-start',
        flexDirection: 'row',
        padding: 20
    },
    headerImage: {
        width: 48,
        height: 48,
        borderRadius: 24,
        marginRight: 10,
    },
    addImage: {
        width: 24,
        height: 24,
    }
})