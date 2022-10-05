import React from "react";
import { StyleSheet, View } from "react-native";
import { colors } from "../../assets/colors";

export const friendStyle = StyleSheet.create({
    divider: {
        backgroundColor: colors.ui.divider,
        width: "100%",
        height: 1
    },
    mainContainer: {
        flex: 1,
        backgroundColor: colors.ui.primary
    },
    topContainer: {
        backgroundColor: colors.ui.primary,
        width: '100%',
        height: 80,
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
    modal: {
        paddingHorizontal: 40
    },
    modalContainer: {
        height: 250,
        backgroundColor: colors.ui.white,
        flexDirection: 'column',
        justifyContent: "space-around",
        alignItems: 'center',
        borderRadius: 20,
        paddingVertical: 20,
        paddingHorizontal: 50
    },
    modalImage: {
        width: 56,
        height: 56,
        borderRadius: 28,
    },
    modalText: {
        color: colors.text.black,
        textAlign: "center",
        paddingHorizontal: 10
    },
    buttonContainer: {
        marginTop: 20,
        flexDirection: 'row',
    },
    acceptButton: {
        backgroundColor: colors.ui.primary,
        color: colors.text.white,
        paddingHorizontal: 20,
        borderRadius: 10,
        paddingVertical: 10,
        marginLeft: 10
    },
    declineButton: {
        backgroundColor: colors.ui.gray,
        color: colors.text.black,
        paddingHorizontal: 20,
        borderRadius: 10,
        paddingVertical: 10,
        marginRight: 10
    }
})

export const createGroup = StyleSheet.create({
    container: {
        height: 80,
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
    }
})
export const searchStyle = StyleSheet.create({
    divider: {
        backgroundColor: colors.ui.divider,
        width: "100%",
        height: 1
    },
    mainContainer: {
        flex: 1,
        backgroundColor: colors.ui.white
    },
    topContainer: {
        backgroundColor: colors.ui.white,
        width: '100%',
        height: 50,
        flexDirection: 'row',
        paddingHorizontal: 25,
        paddingVertical: 15
    },
    container: {
        backgroundColor: colors.ui.white,
        height: 60
    },
    scrollContainer: {
        flex: 1,
        backgroundColor: colors.ui.white
    },
    button: {
        alignItems: 'center',
        justifyContent: 'center',
        width: 24,
        height: 24,
        borderColor: colors.bg.gray,
        borderWidth: 1,
        borderRadius: 12,
        backgroundColor: colors.ui.white,
    },
    buttonActive: {
        alignItems: 'center',
        justifyContent: 'center',
        width: 24,
        height: 24,
        borderColor: colors.bg.gray,
        borderWidth: 0,
        borderRadius: 12,
        backgroundColor: colors.ui.primary,
    },
    text: {
        color: colors.text.lightgray,
        fontSize: 16,
        paddingLeft: 10
    },
    space: {
        padding: 20
    },
    container: {
        paddingHorizontal: 20,
        backgroundColor: colors.ui.white,
    },
    searchStyle: {
        color: colors.text.white,
        height: 44,
        borderRadius: 8,
        backgroundColor: colors.ui.search,
        color: colors.text.black,
        marginBottom: 10,
    }
})