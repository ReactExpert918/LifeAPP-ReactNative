import { StyleSheet } from 'react-native';
import { colors } from '../../../../assets/colors';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    alignItems: 'center',
  },
  leftContainer: {
    alignItems: 'flex-start',
    justifyContent: 'center',
    width: '100%',
    marginTop: 15,
  },
  avatarContainer: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: colors.bg.lightgray,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  avatarImage: {
    width: '100%',
    height: '100%',
  },
  iconImage: {
    width: 20,
    height: 20,
    position: 'absolute',
    left: 40,
    top: 40,
  },
  loginButton: {
    width: '100%',
    padding: 4,
    marginTop: 16,
  },
});
