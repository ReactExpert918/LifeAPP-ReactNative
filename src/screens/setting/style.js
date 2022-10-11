import { StyleSheet } from 'react-native';
import { colors } from '../../assets/colors';

export const SettingStyle = StyleSheet.create({
  container: {
    // padding: 10,
    flex: 1,
  },
  topContainer: {
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.bottom,
    paddingHorizontal: 10,
    paddingVertical: 20,
  },
  title: {
    fontSize: 20,
    color: colors.text.black
  },
  mainContainer: {
    paddingHorizontal: 10,
  },
  divider: {
    backgroundColor: colors.ui.bottom,
    width: '100%',
    height: 1,
  },
  signout: {
    position: 'absolute',
    bottom: 40,
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20
  },
  image: {
    width: 36,
    height: 36,
  },
  text: {
    paddingHorizontal: 20,
    fontSize: 18,
    color: 'red'
  },
  avatarContanier: {
    width: '100%',
    height: 200,
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarImage: {
    width: 100,
    height: 100,
    borderRadius: 50,
    margin: 'auto'
  },
  iconImage: {
    width: 30,
    height: 30,
    position: 'absolute',
    left: 65,
    top: 75,
    overflow: 'hidden',
    borderRadius: 15,
    borderColor: 'white',
    borderWidth: 2
  }
});
