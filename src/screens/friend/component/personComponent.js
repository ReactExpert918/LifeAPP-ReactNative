import { React } from "react"
import { useDispatch } from "react-redux";
import { colors } from "../../../assets/colors";
import { images } from "../../../assets/pngs"
import { TouchableOpacity, View, Text, Image } from "react-native";
import { personComponentStyle } from "./friendComponentStyle";
import Ionicons from "react-native-vector-icons/Ionicons";
import { FRIEND_STATE } from '../../../constants/redux'

export const PersonComponent = ({CELLInfo, onNavigate, click}) => {
    const dispatch = useDispatch();
    const toggleShow = () => {
        dispatch({
            type: FRIEND_STATE.REQUEST,
            show: true
        })
    }
    return(
        <TouchableOpacity 
            style={personComponentStyle.container} 
            onPress={onNavigate}
        >
            <Image 
                style={personComponentStyle.headerImage} 
                source={images.ic_default_profile}
            />
            <View style={{flex:1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                {CELLInfo && (
                <Text variant="label" style={{color: colors.text.black}}>
                    {CELLInfo.username}
                </Text>
                )}
                 <TouchableOpacity>
                    {
                        CELLInfo.type == 'request' && (
                            <Ionicons 
                                name="md-add-circle-outline" 
                                size={25} 
                                style={personComponentStyle.addFriend} 
                                onPress={toggleShow}
                            /> 
                        )
                    }
                    {
                        CELLInfo.type == "recommand" && (
                            <Image 
                                style={personComponentStyle.addImage} 
                                source={images.ic_add_friend} 
                                onPress={() => onClick(true)}
                            />
                        )
                    }
                    {
                        CELLInfo.type == "search" && (
                            <Image 
                                style={personComponentStyle.addImage} 
                                source={images.ic_add_friend} 
                                onPress={() => click(true)}
                            />
                        )
                    }
                </TouchableOpacity>
            </View>
        </TouchableOpacity>
       
    )
}
