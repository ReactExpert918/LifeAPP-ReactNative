import { TouchableOpacity, Text, Image, StyleSheet } from "react-native"

const style = StyleSheet.create({
    image: {
        width: 32,
        height: 32,
    },
    button: {
        alignItems: 'center',
        justifyContent: 'center'
    }
})

export const Button = ({image, text, color}) => {
    return(
        <TouchableOpacity style={style.button}>
            <Image source={image} style={style.image} />
            <Text 
                varient="label"
                style={{color: `${color}`}}
            >
                {text}
            </Text>
        </TouchableOpacity>
    )
}