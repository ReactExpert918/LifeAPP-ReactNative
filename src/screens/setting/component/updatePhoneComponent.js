import React, { useRef, useState } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import auth from '@react-native-firebase/auth';
import { firebaseSDK } from '../../../services/firebase';
import Ionicons from 'react-native-vector-icons/Ionicons';
import SmoothPinCodeInput from 'react-native-smooth-pincode-input';
import { updateExpand } from './settingComponentStyle';
import PhoneInput from 'react-native-phone-number-input';
import { SETTING_STATE } from '../../../constants/redux';

export const UpdatePhoneComponent = ({ title, click, phone }) => {
  const [phoneNumber, setPhoneNumber] = useState('');
  const phoneInput = useRef(null);
  const [visible, setVisible] = useState(true);
  const [code, setCode] = useState('');
  const pinInput = useRef(null);
  const [confirm, setConfirm] = useState('');
  const { user } = useSelector((state) => state.Auth);

  const dispatch = useDispatch();

  const onSubmit = async() => {
    console.log(phone, phoneNumber);
    if(visible) {
      if(phone != phoneNumber) {
        let result = await firebaseSDK.signInWithPhoneNumber(phoneNumber);
        setConfirm(result.verificationId);
        setVisible(false);
      }
    }
    else {
      let cred = await firebaseSDK.getCredential(confirm, code);
      await auth().currentUser.updatePhoneNumber(cred);
      await firebaseSDK.updatePhoneNumber(user.id, phoneNumber);
      click(false);
      dispatch({
        type: SETTING_STATE.SETTING_UPDATE,
        payload: { show: true, data: title},
      });
    }
  };
  return(
    <>
      <View 
        style={visible ? 
          updateExpand.container 
          : updateExpand.phoneContainer}
      >    
      </View>
      <View 
        style={visible ? 
          updateExpand.expand : 
          updateExpand.phone}
      >
        <Ionicons 
          style={visible ? 
            updateExpand.close : 
            updateExpand.passclose}
          name="md-close-sharp" 
          size={25}
          onPress={() => click('')}
        />
        <Text style={updateExpand.title}>
          {visible ? `Update ${title}` : 'Verify Phone'}
        </Text>
        {
          visible ? (
            <View style={updateExpand.input}>
              <Text style={updateExpand.text}>{title}</Text>
              <PhoneInput
                ref={phoneInput}
                defaultValue={phoneNumber}
                defaultCode={'JP'}
                layout="first"
                autoFocus
                onChangeFormattedText={(text) => setPhoneNumber(text)}
                containerStyle={{ width: '100%' }}
              />
            </View>
          ) : (
            <View style={updateExpand.input}>
              <Text style={updateExpand.phoneText}>
                Please Enter the {'\n'} OTP received in your device
              </Text>
              <SmoothPinCodeInput
                style={updateExpand.inputText}
                ref={pinInput}
                value={code}
                onTextChange={(text) => setCode(text)}
                codeLength={6}
                cellStyle={{
                  borderWidth: 2,
                  borderColor: 'gray',
                }}
                cellSpacing={12}
                cellStyleFocused={{
                  borderColor: 'black',
                }}
                animationFocused='pulse'
              />
            </View>
          )
        }
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