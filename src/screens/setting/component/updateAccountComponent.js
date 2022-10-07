/* eslint-disable react/prop-types */
/* eslint-disable no-unused-vars */
import React from 'react';
import { Text, View, Image, TouchableOpacity, TextInput } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { images } from '../../../assets/pngs';
import { updateExpand } from './settingComponentStyle'; 

export const UpdateAccount = ({ title, click }) => {
  return(
    <>
      <View style={updateExpand.container}></View>
      <View style={updateExpand.expand}>
        <Ionicons 
          style={updateExpand.close} 
          name="md-close-sharp" 
          size={25}
          onPress={() => click(false)}
        />
        <Text style={updateExpand.title}>Update {title}</Text>
        <View style={updateExpand.input}>
          <Text style={updateExpand.text}>{title}</Text>
          <TextInput 
            style={updateExpand.inputText}
            value="Shane Watson"
          />
          {/* <Text>Username not available, try another!</Text> */}
        </View>
        <TouchableOpacity 
          style={updateExpand.button}
        >
          <Text style={updateExpand.buttonText}>SUBMIT</Text>
        </TouchableOpacity>
      </View>
    </>
  );
};