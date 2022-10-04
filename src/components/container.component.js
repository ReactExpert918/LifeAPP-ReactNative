import React from 'react';
import PropTypes from 'prop-types';
import { StyleSheet, SafeAreaView } from 'react-native';

const contain = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export const ContainerComponent = ({ children }) => {
  return <SafeAreaView style={contain.container}>{children}</SafeAreaView>;
};

ContainerComponent.propTypes = {
  children: PropTypes.any,
};
