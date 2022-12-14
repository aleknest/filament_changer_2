#ifndef UTILS_H
#define UTILS_H

#include <Arduino.h>

bool toInt(const String& s, int& i);
bool toUnsigned(const String& s, unsigned& i);
bool toFloat(const String& s, float& f);

template<typename Data>
class Vector
{
  private:
    size_t d_size;
    size_t d_capacity;
    Data *d_data;

    void resize()
    {
      d_capacity = d_capacity ? d_capacity*2 : 1;
      Data *newdata = (Data *)malloc(d_capacity*sizeof(Data));
      memcpy(newdata, d_data, d_size * sizeof(Data));
      free(d_data); d_data = newdata;
    }
  public:
    Vector()
      : d_size(0)
      , d_capacity(0)
      , d_data(0)
    {
    }

    Vector(Vector const &other)
      : d_size(other.d_size)
      , d_capacity(other.d_capacity)
      , d_data(0)
    {
      d_data = (Data *)malloc(d_capacity*sizeof(Data));
      memcpy(d_data, other.d_data, d_size*sizeof(Data));
    }

    ~Vector()
    {
      free(d_data);
    }
    Vector &operator=(Vector const &other)
    {
      free(d_data);
      d_size = other.d_size;
      d_capacity = other.d_capacity;
      d_data = (Data *)malloc(d_capacity*sizeof(Data));
      memcpy(d_data, other.d_data, d_size*sizeof(Data));
      return *this;
    }

    void push_back(Data const &x)
    {
      if (d_capacity == d_size)
        resize();
      d_data[d_size++] = x;
    }

    size_t size() const
    {
      return d_size;
    }

    Data const &operator[](size_t idx) const
    {
      return d_data[idx];
    }

    Data &operator[](size_t idx)
    {
      return d_data[idx];
    }
};

#endif
