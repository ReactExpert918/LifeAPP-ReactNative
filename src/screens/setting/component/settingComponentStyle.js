import { StyleSheet, Dimensions } from 'react-native';
import { white } from 'react-native-paper/lib/typescript/styles/colors';
import { color } from 'react-native-reanimated';
import { colors } from '../../../assets/colors';

export const styles = StyleSheet.create({
  container: {
    // paddingHorizontal: 10,
    paddingVertical: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.bottom,
  },
  touch: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  left: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  image: {
    width: 36,
    height: 36,
  },
  text: {
    paddingHorizontal: 20,
    color: colors.text.black,
    fontSize: 18,
  },
  delAccount: {
    paddingHorizontal: 20,
    color: colors.text.red,
    fontSize: 18,
  },
  right: {},
});

export const accountSettingListStyle = StyleSheet.create({
  container: {
    // paddingHorizontal: 10,
    paddingVertical: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.bottom,
  },
  left: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  image: {
    width: 36,
    height: 36,
  },
  textTitle: {
    paddingHorizontal: 10,
    color: colors.text.gray,
    fontSize: 15,
    paddingRight: 10,
  },
  text: {
    paddingHorizontal: 10,
    color: colors.text.lightgray,
    fontSize: 15,
    paddingRight: 10,
  },
  delAccount: {
    paddingHorizontal: 10,
    color: colors.text.red,
    fontSize: 15,
  },
});

export const updateExpand = StyleSheet.create({
  container: {
    position: 'absolute',
    height: Dimensions.get('window').height - 300,
    width: '100%',
    backgroundColor: 'black',
    top: 0,
    opacity: 0.5,
  },
  phoneContainer: {
    position: 'absolute',
    height: Dimensions.get('window').height - 330,
    width: '100%',
    backgroundColor: 'black',
    top: 0,
    opacity: 0.5,
  },
  phone: {
    position: 'absolute',
    height: 330,
    backgroundColor: colors.ui.white,
    flex: 1,
    bottom: 0,
    width: '100%',
    borderTopLeftRadius: 40,
    borderTopRightRadius: 40,
    flexDirection: 'column',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  phoneText: {
    color: colors.text.black,
    fontSize: 24,
    paddingBottom: 20,
    textAlign: 'center',
    fontWeight: 'bold',
  },
  close: {
    position: 'absolute',
    bottom: 230,
    right: 30,
    color: colors.ui.primary,
  },
  passclose: {
    position: 'absolute',
    bottom: 260,
    right: 30,
    color: colors.ui.primary,
  },
  passexpand: {
    position: 'absolute',
    height: 330,
    backgroundColor: colors.ui.white,
    flex: 1,
    bottom: 0,
    width: '100%',
    borderTopLeftRadius: 40,
    borderTopRightRadius: 40,
    flexDirection: 'column',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  expand: {
    position: 'absolute',
    height: 300,
    backgroundColor: colors.ui.white,
    flex: 1,
    bottom: 0,
    width: '100%',
    borderTopLeftRadius: 40,
    borderTopRightRadius: 40,
    flexDirection: 'column',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: 20,
    paddingBottom: 10,
  },
  title: {
    color: colors.text.primary,
    textAlign: 'center',
    paddingHorizontal: 10,
    fontWeight: 'bold',
    fontSize: 18,
    paddingTop: 20,
  },
  input: {
    flexDirection: 'column',
    justifyContent: 'center',
    position: 'relative',
    flex: 1,
    width: '100%',
  },
  text: {
    paddingVertical: 10,
    fontSize: 16,
    color: colors.text.lightgray,
  },
  inputText: {
    backgroundColor: '#f2f2f2',
    paddingHorizontal: 10,
    width: Dimensions.get('window').width - 50,
    fontSize: 16,
    color: colors.text.black,
  },
  warnText: {
    backgroundColor: '#FADCE6',
    paddingHorizontal: 10,
    width: Dimensions.get('window').width - 50,
    fontSize: 16,
    color: colors.text.black,
  },
  button: {
    backgroundColor: colors.ui.primary,
    paddingHorizontal: (Dimensions.get('window').width - 120) / 2,
    borderRadius: 5,
    paddingVertical: 15,
    marginBottom: 10,
  },
  buttonText: {
    fontWeight: 'bold',
    fontSize: 18,
    color: colors.text.white,
  },
  textContent: {
    color: colors.text.black,
    padding: 30,
  },
});

export const updateSuccess = StyleSheet.create({
  container: {
    position: 'absolute',
    flex: 1,
    top: -60,
    justifyContent: 'center',
    alignItems: 'center',
    height: Dimensions.get('window').height,
    width: '100%',
  },
  background: {
    position: 'absolute',
    flex: 1,
    top: 0,
    opacity: 0.5,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
    height: Dimensions.get('window').height,
    width: '100%',
    backgroundColor: 'black',
  },
  main: {
    width: Dimensions.get('window').width-60,
    backgroundColor: 'white',
    zIndex: 10000,
    height: 250,
    borderRadius: 30,
    padding: 30,
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  icon: {
    color: '#19a52e',
  },
  text: {
    fontSize: 20,
    color: colors.text.black,
    textAlign: 'center',
    fontWeight: '600'
  },
  button: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.text.primary,
  }
});
