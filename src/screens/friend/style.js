import React from 'react';
import { StyleSheet, View } from 'react-native';
import { colors } from '../../assets/colors';

export const friendStyle = StyleSheet.create({
  divider: {
    backgroundColor: colors.ui.divider,
    width: '100%',
    height: 1,
  },
  mainContainer: {
    flex: 1,
    backgroundColor: colors.ui.primary,
  },
  topContainer: {
    backgroundColor: colors.ui.primary,
    width: '100%',
    height: 80,
    flexDirection: 'row',
    padding: 10,
  },
  container: {
    flex: 1,
    backgroundColor: colors.ui.white,
  },
  scrollContainer: {
    flex: 1,
    backgroundColor: colors.ui.white,
  },
});

export const createGroup = StyleSheet.create({
  container: {
    height: 80,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'flex-start',
    flexDirection: 'row',
    padding: 10,
  },
  headerImage: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 10,
  },
});
