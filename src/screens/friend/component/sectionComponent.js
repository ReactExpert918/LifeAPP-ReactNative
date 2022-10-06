import React from 'react';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { colors } from '../../../assets/colors';
import { TouchableOpacity, View, Text } from 'react-native';
import { sectionComponentStyle } from './friendComponentStyle';

export const SectionComponent = ({ showContent, onClick, title }) => {
  return (
    <TouchableOpacity onPress={onClick}>
      <View style={sectionComponentStyle.container}>
        <View style={sectionComponentStyle.textContainer}>
          <Text variant="label" style={{ color: colors.text.black }}>
            {title}
          </Text>
        </View>
        <Ionicons
          style={sectionComponentStyle.icon}
          name={showContent ? 'md-chevron-down' : 'md-chevron-up'}
          size={24}
        />
      </View>
    </TouchableOpacity>
  );
};
