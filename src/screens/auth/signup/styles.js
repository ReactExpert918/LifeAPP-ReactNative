import { StyleSheet } from 'react-native';
import { colors } from '../../../assets/colors';

export const styles = StyleSheet.create({
  circle: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginLeft: 4,
  },
  container: {
    flex: 1,
    backgroundColor: colors.ui.white,
  },
  header: {
    height: 48,
    width: '100%',
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
  },
  leftIcon: {
    position: 'absolute',
    left: 10,
  },
  loader: {
    position: 'absolute',
    left: 0,
    top: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg.darkalpha,
  },
});
