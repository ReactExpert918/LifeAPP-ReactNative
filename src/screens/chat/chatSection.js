/* eslint-disable react/prop-types */
import { React } from 'react';
import { PersonComponent } from './component/personComponent';

export const ChatSection = ({items, onNavigate}) => {

  return (
    <>
      {
        items.map((data, index) => {
          return (
            <PersonComponent
              CELLInfo={data}
              key={`data-${index}`}
              onNavigate={onNavigate}
            />
          );
        })}
    </>
  );
};