/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import { useSelector, useDispatch } from 'react-redux';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { SETTING_STATE } from '../../../constants/redux';
import { updateSuccess } from './settingComponentStyle';

export const SccessUpdate = () => {
  const dispatch = useDispatch();
  const setting = useSelector((state)=> state.Setting.payload);
  const close = ()=> {
    dispatch({
      type: SETTING_STATE.SETTING_UPDATE,
      payload: { show: false, data: ''},
    });
  };
  return(
    <View style={updateSuccess.container}>
      <View style={updateSuccess.background}></View>
      <View style={updateSuccess.main}>
        <Ionicons 
          style={updateSuccess.icon}
          name="md-checkmark-circle"
          size={70}
        />
        <Text style={updateSuccess.text}>
        Successfully updated the {setting.data}
        </Text>
        <TouchableOpacity onPress={close}>
          <Text style={updateSuccess.button}>
            OKAY
          </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

