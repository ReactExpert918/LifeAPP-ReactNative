/* eslint-disable react/prop-types */
import React, { useState } from 'react';
import { Text, View, Alert, TouchableOpacity, TextInput } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { updateExpand } from './settingComponentStyle'; 
import { colors } from '../../../assets/colors';
import { firebaseSDK } from '../../../services/firebase';

export const UpdatePassword = ({ title, click}) => {
  const [pass, setPass] = useState('');
  const [confirm, setConfirm] = useState('');

  const onSubmit = async () => {
    if (!pass) {
      Alert.alert('Attention', 'Please enter password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (pass.length < 6) {
      Alert.alert('Attention', 'Please enter correct Password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (!confirm) {
      Alert.alert('Attention', 'Please confirm password!', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    if (pass != confirm) {
      Alert.alert('Attention', 'Password doesn\'t match', [
        {
          text: 'OK',
          onPress: () => null,
          style: 'cancel',
        },
      ]);
      return;
    }

    await firebaseSDK.updatePassword(pass);
    console.log('-------------------');
    click(title);
  };

  return(
    <>
      <View style={updateExpand.container}></View>
      <View style={updateExpand.passexpand}>
        <Ionicons 
          style={updateExpand.passclose} 
          name="md-close-sharp" 
          size={25}
          onPress={() => click(false)}
        />
        <Text style={updateExpand.title}>Update {title}</Text>
        <View style={updateExpand.input}>
          <Text style={updateExpand.text}>{title}</Text>
          <TextInput
            mode="outlined"
            placeholder="Password"
            autoCapitalize="none"
            secureTextEntry={true}
            value={pass}
            onChangeText={(text) => setPass(text)}
            outlineColor={'transparent'}
            activeOutlineColor={'transparent'}
            selectionColor={colors.ui.primary}
            style={{ width: '100%' }}
          />
        </View>
        <View style={updateExpand.input}>
          <Text style={updateExpand.text}>Confirm {title}</Text>
          <TextInput
            mode="outlined"
            placeholder="Confirm Password"
            autoCapitalize="none"
            secureTextEntry={true}
            value={confirm}
            onChangeText={(text) => setConfirm(text)}
            outlineColor={'transparent'}
            activeOutlineColor={'transparent'}
            selectionColor={colors.ui.primary}
            style={{ width: '100%' }}
          />
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