#ifndef BASE_H
#define BASE_H

class base_indicator
{
protected:
  virtual void draw() = 0;
public:
  base_indicator();
  ~base_indicator();

  virtual void set_state(const int a_index, const bool a_value) = 0;
  virtual void set_state(const int a_index, const bool a_value, const float a_analog) = 0;
  virtual void set_distance(const float a_value) = 0;
};

#endif
