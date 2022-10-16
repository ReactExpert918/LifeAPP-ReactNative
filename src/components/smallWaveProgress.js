/* eslint-disable */
import * as React from 'react';
import Svg, { G, Rect } from 'react-native-svg';

const SmallWaveProgress = ({
  progress = 70,
  color = 'white',
  width = 200,
  ...props
}) => (
  <Svg
    width={width || 200}
    height={15}
    viewBox="0 0 200 15"
    preserveAspectRatio="none"
    fill="none"
    {...props}
  >
    <G>
      {Array(50)
        .fill('')
        .map((_, index) => {
          const x = 4 * index;
          const height = 15 - Math.floor(Math.random() * 12);
          const y = (15 - height) / 2;
          const fillOpacity = index * 2 <= progress ? 1 : 0.2;
          return (
            <Rect
              width={2}
              x={x}
              y={y}
              height={height}
              fill={color}
              fillOpacity={fillOpacity}
            />
          );
        })}
    </G>
  </Svg>
);

export default SmallWaveProgress;
