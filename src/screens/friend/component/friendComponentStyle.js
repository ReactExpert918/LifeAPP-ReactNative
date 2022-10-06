import { StyleSheet, Dimensions } from 'react-native';
import { colors } from '../../../assets/colors';

export const sectionComponentStyle = StyleSheet.create({
  container: {
    height: 50,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    paddingHorizontal: 20,
  },
  textContainer: {
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'center',
  },
  icon: {
    paddingRight: 0,
  },
});

export const personComponentStyle = StyleSheet.create({
  container: {
    height: 60,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'flex-start',
    flexDirection: 'row',
    padding: 20,
  },
  headerImage: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 10,
  },
  addImage: {
    width: 24,
    height: 24,
  },
  addFriend: {
    size: 24,
    color: colors.ui.primary,
    position: 'absolute',
    top: -10,
    right: 0,
  },
});

export const expandStyle = StyleSheet.create({
  container: {
    position: 'absolute',
    height: Dimensions.get('window').height - 350,
    width: '100%',
    backgroundColor: 'black',
    top: 0,
    opacity: 0.5,
  },
  checkIcon: {
    position: 'absolute',
    bottom: 250,
    left: Dimensions.get('window').width / 2 + 28,
    color: colors.ui.green,
    borderColor: colors.ui.white,
    borderRadius: 12.5,
    border: 2,
  },
  close: {
    position: 'absolute',
    bottom: 300,
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
    paddingHorizontal: 50,
  },
  modalImage: {
    width: 80,
    height: 80,
    borderRadius: 40,
    marginTop: 20,
    borderColor: colors.ui.primary,
    border: 2,
  },
  modalText: {
    color: colors.text.black,
    textAlign: 'center',
    paddingHorizontal: 10,
    fontWeight: 'bold',
    fontSize: 16,
  },
  modalText1: {
    color: colors.text.gray,
    textAlign: 'center',
    paddingHorizontal: 10,
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
