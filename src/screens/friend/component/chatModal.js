import React from "react";
import { useDispatch } from "react-redux";
import { View, Text, Image,  TouchableOpacity } from "react-native";
import Modal from "react-native-modal";
import { colors } from "../../../assets/colors";
import { images } from "../../../assets/pngs";
import { friendStyle } from "../style";
import { FRIEND_STATE } from '../../../constants/redux'

export const ChatModal = (props) => {
    const dispatch = useDispatch();
    const handleModal = () => {
        dispatch({
            type: FRIEND_STATE.REQUEST,
            show: false
        })
    };

    return(
        <Modal 
            isVisible={props.show} 
            style={friendStyle.modal}
            animationInTiming={1000}
            animationOutTiming={1000}
            backdropTransitionInTiming={800}
            backdropTransitionOutTiming={800}
        >
            <View style={friendStyle.modalContainer}>
                <Image 
                    style={friendStyle.modalImage} 
                    source={images.ic_default_profile}
                />
                <Text style={friendStyle.modalText}>
                    Do you want to add &nbsp;
                    <Text style={{fontWeight: 'bold', color: colors.text.primary}}>
                        Andrea
                    </Text>
                    &nbsp; your friend list ?
                </Text>
                <View style={friendStyle.buttonContainer}>
                    <TouchableOpacity 
                        style={friendStyle.declineButton}
                        onPress={handleModal}
                    >
                        <Text style={{color: "black"}}>Decline</Text>
                    </TouchableOpacity>
                    <TouchableOpacity 
                        style={friendStyle.acceptButton}
                        onPress={handleModal}
                    >
                        <Text style={{color: "white"}}>Accept</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </Modal>
    )
}