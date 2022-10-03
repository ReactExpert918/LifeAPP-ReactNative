import { React } from "react"
import { StyleSheet, Text } from "react-native"
import Ionicons from "react-native-vector-icons/Ionicons";
import { HeaderComponent } from "../../../components/header.component"
import { colors } from "../../../assets/colors";

const FriendHeaderStyle = StyleSheet.create({
    iconSetting: {
        size: 24,
        color: colors.ui.white,
        position: "absolute",
        left: 10,
    },
    iconClose: {
        size: 24,
        color: colors.ui.white,
        position: "absolute",
        right: 10,
    },
    text: {
        fontSize: 20,
        color: colors.text.white
    }
})

export const FriendHeader = () => {

    return(
        <HeaderComponent>
            <Ionicons 
                name="md-settings-outline" 
                size={25} 
                style={FriendHeaderStyle.iconSetting}
            />
            <Text 
                style={FriendHeaderStyle.text}
            >
                Add Friends
            </Text>
            <Ionicons 
                name="md-close" 
                size={25} 
                style={FriendHeaderStyle.iconClose}
            />
        </HeaderComponent>
    )
}