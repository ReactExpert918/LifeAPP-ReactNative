import { StyleSheet } from 'react-native';
import { colors } from '../../../assets/colors';

export const chatSearchComponentStyle = StyleSheet.create({
  container: {
    paddingHorizontal: 10,
    backgroundColor: colors.ui.primary,
    flex: 1
  },
  searchStyle: {
    color: colors.text.white,
    height: 40,
    borderRadius: 8,
    backgroundColor: colors.ui.secondary,
  }
});

export const personComponentStyle = StyleSheet.create({
  container: {
    height: 60,
    width: '100%',
    alignItems: 'center',
    justifyContent: 'flex-start',
    flexDirection: 'row',
    padding: 20
  },
  headerImage: {
    width: 48,
    height: 48,
    borderRadius: 24,
    marginRight: 10,
  },
  newMessage: {
    width: 24,
    height: 24,
    backgroundColor: colors.ui.primary,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center'
  }
});