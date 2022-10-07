/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { settingListStyle } from './settingComponentStyle';

export const AccountSettingListComponent = ({ title, value, type, click }) => {
  return(
    <View style={settingListStyle.container}>
      <View style={settingListStyle.left}>
        <Text 
          style={(type=='button') ? settingListStyle.delAccount :settingListStyle.text}
        >
          {title}
        </Text>
      </View>
      <View style={settingListStyle.left}>
        <Text style={settingListStyle.text}>
          {(type!=='pass') ? value : '.......' }
        </Text>
        <Ionicons 
          name="md-chevron-forward-sharp"
          size={25}
          onPress={() => click(title)}
        />
      </View>
    </View>
  );
};

