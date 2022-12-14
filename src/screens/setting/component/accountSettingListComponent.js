/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { accountSettingListStyle } from './settingComponentStyle';


export const AccountSettingListComponent = ({ title, value, type, click }) => {
  const onClick = () => {
    click(title);
  };
  return(
    <TouchableOpacity style={accountSettingListStyle.container}  onPress={onClick}>
      <View style={accountSettingListStyle.left}>
        <Text 
          style={(type=='button') ? accountSettingListStyle.delAccount :accountSettingListStyle.textTitle}
        >
          {title}
        </Text>
      </View>
      <View style={accountSettingListStyle.left}>
        <Text style={accountSettingListStyle.text}>
          {(type!=='pass') ? value : '.......' }
        </Text>
        <Ionicons 
          style={accountSettingListStyle.icon}
          name="md-chevron-forward-sharp"
          size={25}
        />
      </View>
    </TouchableOpacity>
  );
};

