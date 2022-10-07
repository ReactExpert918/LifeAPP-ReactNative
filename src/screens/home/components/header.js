import { React } from 'react';
import { StyleSheet, Text } from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import SimpleLineIcons from 'react-native-vector-icons/SimpleLineIcons';
import PropTypes from 'prop-types';

import { HeaderComponent } from '../../../components/header.component';
import { colors } from '../../../assets/colors';

const styles = StyleSheet.create({
  iconSetting: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    left: 20,
  },
  iconClose: {
    size: 24,
    color: colors.ui.white,
    position: 'absolute',
    right: 20,
  },
  text: {
    fontSize: 20,
    color: colors.text.white,
    fontWeight: 'bold',
  },
});

const Header = ({ back, title }) => {
  return (
    <HeaderComponent>
      <Ionicons
        name="md-settings-outline"
        size={25}
        style={styles.iconSetting}
      />
      <Text style={styles.text}>{title}</Text>
      <SimpleLineIcons name="user-follow" size={25} style={styles.iconClose} />
    </HeaderComponent>
  );
};

export default Header;

Header.propTypes = {
  back: PropTypes.func,
  title: PropTypes.string,
};
