/* eslint-disable react/prop-types */
import React from 'react';
import { Text, View, Image, TouchableOpacity } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { styles } from './settingComponentStyle';

export const SettingListComponent = ({ icon, title, onClick }) => {
  return (
    <TouchableOpacity onPress={onClick} style={styles.container}>
      <View style={styles.left}>
        <Image source={icon} style={styles.image} />
        <Text style={styles.text}>{title}</Text>
      </View>
      <Ionicons
        style={styles.right}
        name="md-chevron-forward-sharp"
        size={25}
      />
    </TouchableOpacity>
  );
};
