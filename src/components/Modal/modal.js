/* eslint-disable no-undef */
/* eslint-disable react/prop-types */
import React from 'react';
import { View, Text, Image,  TouchableOpacity,  } from 'react-native';
import Modal from 'react-native-modal';
import { colors } from '../../../assets/colors';
import { images } from '../../../assets/pngs';

export const ModalComponent = (props) => {
  
  return(
    <Modal 
      isVisible={props.show} 
      animationInTiming={1000}
      animationOutTiming={1000}
      backdropTransitionInTiming={800}
      backdropTransitionOutTiming={800}
    >
      <View style={style.modalContainer}>
        <Image 
          style={style.modalImage} 
          source={images.ic_default_profile}
        />
        <Text style={style.modalText}>
            Do you want to add &nbsp;
          <Text style={{fontWeight: 'bold', color: colors.text.primary}}>
            Andrea
          </Text>
          &nbsp; your friend list ?
        </Text>
        <View style={style.buttonContainer}>
          <TouchableOpacity 
            style={style.acceptButton}
            onPress={handleModal}
          >
            <Text style={{color: 'white'}}>Accept</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};