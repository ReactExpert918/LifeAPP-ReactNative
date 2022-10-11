import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import { Searchbar } from 'react-native-paper';
import { colors } from '../../../assets/colors';

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: colors.ui.primary,
  },
});

const SearchBar = () => {
  const [searchKeyword, setSearchKeyword] = useState('');

  return (
    <View style={styles.container}>
      <Searchbar
        clearAccessibilityLabel="Cancel"
        placeholder="Search"
        value={searchKeyword}
        onChangeText={(text) => setSearchKeyword(text)}
        onSubmitEditing={() => console.log('Search')}
      />
    </View>
  );
};

export default SearchBar;
