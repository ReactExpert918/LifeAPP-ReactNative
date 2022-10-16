/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { settingListStyle } from './settingComponentStyle';

export const SettingListComponent = ({ icon, title, click }) => {
  return(
    <TouchableOpacity onPress={click}>
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
        />
      </View>
    </TouchableOpacity>

  );
};

