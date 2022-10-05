import React from "react";
import { View, Text, Image,  TouchableOpacity  } from "react-native";
import { images } from "../../../assets/pngs";
import Ionicons from "react-native-vector-icons/Ionicons";
import { expandStyle } from "./friendComponentStyle";
export const ChatExpand = ({ visible }) => {
    return(
        <>
            <View style={expandStyle.container}></View>
            <View style={expandStyle.expand}>
                <Ionicons 
                    style={expandStyle.close} 
                    name="md-close-sharp" 
                    size={25}
                    onPress={() => visible(false)}
                />
                <Image 
                    style={expandStyle.modalImage} 
                    source={images.ic_default_profile}
                />
                <Ionicons style={expandStyle.checkIcon} name="checkmark-circle-sharp" size={25} />
                <Text style={expandStyle.modalText}>
                    Andrea Johns
                </Text>
                <Text style={expandStyle.modalText1}>
                    18673920211
                </Text>
                <Text style={expandStyle.textContent}>
                   Successfully added to your friend list
                </Text>
                <TouchableOpacity 
                    style={expandStyle.button}
                >
                    <Text style={expandStyle.buttonText}>Start Chat</Text>
                </TouchableOpacity>
            </View>
        </>
    )
}