import { StyleSheet } from 'react-native';
import { colors } from '../assets/colors';

export const textStyles = StyleSheet.create({
  primaryBold: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.text.primary,
  },
  primaryThin: {
    fontSize: 16,
    fontWeight: '300',
    color: colors.text.primary,
  },
  blackBold: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.text.black,
  },
  grayThin: {
    fontSize: 16,
    fontWeight: '300',
    color: colors.text.gray,
  },
  graySmall: {
    fontSize: 10,
    fontWeight: '300',
    color: colors.text.gray,
  },
  primarySmall: {
    fontSize: 10,
    fontWeight: '300',
    color: colors.text.primary,
  },
  blackSmall: {
    fontSize: 10,
    fontWeight: '300',
    color: colors.text.black,
  },
  blackTitleBold: {
    fontSize: 28,
    fontWeight: '700',
    color: colors.text.black,
  },
});
