/* eslint-disable react/prop-types */
/* eslint-disable no-unused-vars */
import React, { useState } from 'react';
import { useSelector } from 'react-redux';
import { Text, View, Alert, TouchableOpacity, TextInput } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { images } from '../../../assets/pngs';
import { updateExpand } from './settingComponentStyle'; 
import { firebaseSDK } from '../../../services/firebase';
import { isValidEmail } from '../../../utils/validators';

export const UpdateName = ({ title, click, name, username, email }) => {
  const { user } = useSelector((state) => state.Auth);
  const [isName, isSetName] = useState(name);
  const [isUserName, isSetUserName] = useState(username);
  const [isEmail, isSetEmail] = useState(email);
  const [available, setAvailable] = useState(true);

  const onSubmit = async() => {
    if(title == 'Name') {
      if (!isName) {
        Alert.alert('Attention', 'Please enter Name!', [
          {
            text: 'OK',
            onPress: () => null,
            style: 'cancel',
          },
        ]);
        return;
      }
      else {
        let result = await firebaseSDK.updateFullName(user.uid, isName);
        click(false);
      }
    }
    if(title == 'Username') {
      if (!isUserName) {
        Alert.alert('Attention', 'Please enter Username!', [
          {
            text: 'OK',
            onPress: () => null,
            style: 'cancel',
          },
        ]);
        return;
      }
      else {
        let check = await firebaseSDK.checkUserName(user.id, isUserName);
        if(check) {
          setAvailable(false);
        }
        else {
          setAvailable(true);
          let result = await firebaseSDK.updateUserName(user.uid, isUserName);
          firebaseSDK.updateDisplayName(isUserName);
          click(false);
        }
      }
    }
    if(title == 'Email Address') {
      if (!isEmail) {
        Alert.alert('Attention', 'Please enter email!', [
          {
            text: 'OK',
            onPress: () => null,
            style: 'cancel',
          },
        ]);
        return;
      }
      if(!isValidEmail(isEmail)) {
        Alert.alert('Attention', 'Please enter correct email!', [
          {
            text: 'OK',
            onPress: () => null,
            style: 'cancel',
          },
        ]);
        return;
      }
      else {
        await firebaseSDK.updateEmailAddress(user.uid, isEmail);
        firebaseSDK.updateEmail(isEmail);
        click(false);
      }
    }
  };

  return(
    <>
      <View style={updateExpand.container}></View>
      <View style={updateExpand.expand}>
        <Ionicons 
          style={updateExpand.close} 
          name="md-close-sharp" 
          size={25}
          onPress={() => click('')}
        />
        <Text style={updateExpand.title}>Update {title}</Text>
        <View style={updateExpand.input}>
          <Text style={updateExpand.text}>{title}</Text>
          {
            title == 'Name' && (
              <TextInput 
                style={updateExpand.inputText}
                value={isName}
                mode="outlined"
                placeholder="Full Name"
                autoCapitalize="none"
                secureTextEntry={false}
                onChangeText={(text) => isSetName(text)}
                outlineColor={'transparent'}
                activeOutlineColor={'transparent'}
              />
            )
          }
          {
            title == 'Email Address' && (
              <TextInput 
                style={available ? updateExpand.inputText : updateExpand.warnText}
                value={isEmail}
                mode="outlined"
                placeholder="Email"
                autoCapitalize="none"
                secureTextEntry={false}
                onChangeText={(text) => isSetEmail(text)}
                outlineColor={'transparent'}
                activeOutlineColor={'transparent'}
              />
            )
          }
          {
            title == 'Username' && (
              <TextInput 
                style={available ? updateExpand.inputText : updateExpand.warnText}
                value={isUserName}
                mode="outlined"
                placeholder="Username"
                autoCapitalize="none"
                secureTextEntry={false}
                onChangeText={(text) => isSetUserName(text)}
                outlineColor={'transparent'}
                activeOutlineColor={'transparent'}
              />
            )
          }
          {
            !available && 
            (
              <Text style={{color: '#E85A7D'}}>Username not available, try another!</Text>
            ) 
          }
        </View>
        <TouchableOpacity 
          style={updateExpand.button}
          onPress={onSubmit}
        >
          <Text 
            style={updateExpand.buttonText}
          >
            SUBMIT
          </Text>
        </TouchableOpacity>
      </View>
    </>
  );
};