
/* eslint-disable react/prop-types */
import React from 'react';
import PropTypes from 'prop-types';
import { StyleSheet, Text, View } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { colors } from '../assets/colors';

const header = StyleSheet.create({
  container: {
    height: 60,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    backgroundColor: colors.ui.primary,
  },
  iconSetting: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    left: 20,
  },
  iconClose: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    right: 20,
  },
  text: {
    fontSize: 20,
    color: colors.text.white,
    fontWeight: 'bold',
  },
});

export const HeaderComponent = ({ title, firstClick }) => {
  return (
    <View style={header.container}>
      {title == 'Add Friends' && (
        <Ionicons
          name="md-settings-outline"
          size={25}
          style={header.iconSetting}
          onPress={firstClick}
        />
      )}
      {(title == 'Search Friends' || title == 'Account Settings') && (
        <Ionicons
          name="md-chevron-back-sharp"
          size={25}
          style={header.iconSetting}
          onPress={firstClick}
        />
      )}
      <Text style={header.text}>{title}</Text>
      {(title == 'Add Friends' || title == 'Settings' || title == 'Account Settings') && (
        <Ionicons
          name="md-close"
          size={25}
          style={header.iconClose}
        />
      )}
    </View>
  );
};

HeaderComponent.propTypes = {
  children: PropTypes.any,
};
