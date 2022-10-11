/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { settingListStyle } from './settingComponentStyle';

export const SettingListComponent = ({ icon, title, click }) => {
  return(
    <View style={settingListStyle.container}>
      <View style={settingListStyle.left}>
        <Image 
          source={icon}
          style={settingListStyle.image} 
        />
        <Text style={settingListStyle.text}>
          {title}
        </Text>
      </View>
      <Ionicons 
        style={settingListStyle.right}
        name="md-chevron-forward-sharp"
        size={25}
        onPress={click}
      />
    </View>
  );
};

