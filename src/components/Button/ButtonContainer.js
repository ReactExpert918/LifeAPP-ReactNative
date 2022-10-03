import { View, StyleSheet } from "react-native"

const style = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    }
})

export const ButtonContainer = ({children}) => {
    return(
        <View style={style.container}>
            {children}
        </View>
    )
}