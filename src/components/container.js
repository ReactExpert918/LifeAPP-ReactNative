import React from 'react';
import PropTypes from 'prop-types';
import { StyleSheet, SafeAreaView } from 'react-native';
import { colors } from '../assets/colors';

const contain = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.ui.white,
  },
});

const Container = ({ children }) => {
  return <SafeAreaView style={contain.container}>{children}</SafeAreaView>;
};

export default Container;

Container.propTypes = {
  children: PropTypes.any,
};
