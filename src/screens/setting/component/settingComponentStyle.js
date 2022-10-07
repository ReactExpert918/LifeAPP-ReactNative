import { StyleSheet, Dimensions } from 'react-native';
import { colors } from '../../../assets/colors';

export const settingListStyle = StyleSheet.create({
  container: {
    // paddingHorizontal: 10,
    paddingVertical: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderBottomColor: colors.ui.bottom
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
    color: colors.text.lightgray,
    fontSize: 18,
  },
  delAccount: {
    paddingHorizontal: 20,
    color: colors.text.red,
    fontSize: 18
  },
  right: {

  },

});

export const updateExpand = StyleSheet.create({
  container: {
    position: 'absolute',
    height: Dimensions.get('window').height - 350,
    width: '100%',
    backgroundColor: 'black',
    top: 0,
    opacity: 0.5,
  },
  close: {
    position: 'absolute',
    bottom: 270,
    right: 30,
    color: colors.ui.primary,
  },
  expand: {
    position: 'absolute',
    height: 350,
    backgroundColor: colors.ui.white,
    flex: 1,
    bottom: 0,
    width: '100%',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    flexDirection: 'column',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingVertical: 20,
    paddingHorizontal: 20,
    paddingBottom: 10
  },
  title: {
    color: colors.text.primary,
    textAlign: 'center',
    paddingHorizontal: 10,
    fontWeight: 'bold',
    fontSize: 18,
  },
  input: {
    flexDirection: 'column',
    justifyContent: 'flex-start',
    position: 'relative'
  },
  text: {
    position: 'absolute',
    left: -200,
    top: -40
  },
  inputText: {
    backgroundColor: '#f2f2f2',
    position: 'absolute',
    paddingHorizontal: 10, 
    width: Dimensions.get('window').width - 100,
    left: -190,
    top: 0
  },
  button: {
    backgroundColor: colors.ui.primary,
    paddingHorizontal: (Dimensions.get('window').width - 200) / 2,
    borderRadius: 10,
    paddingVertical: 15,
    marginBottom: 30,
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