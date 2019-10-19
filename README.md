# Traindown
**A simple markup language for capturing all the cool shit you do in training.**

Traindown is inspired heavily by [Markdown](https://en.wikipedia.org/wiki/Markdown) and my inability to sit and write out my training. Over the last 16+ years of training, I have recorded *maybe* a few months worth of sessions. After alot of noodling on this, I determined my primary hang up is the input.

I don't like writing with pen and paper (I'm a lefty and ink plus a chalky hand equals illegible smears) and all apps I tried, well, suck. I have to either input everything I'm *going* to do and then check off boxes or I have to enter it as I go. This wouldn't be such a problem if the inputs weren't rife with dropdowns, shitty autocorrect, etc.

Soooo, me being a plain text kind of guy (I am typing this in Vim), I created **Traindown** to facilitate easy input of training session. This could be done ahead of time, during, or after. Doesn't matter. The syntax is optimized for minimal time typing. It does not rely on multiple input fields to capture data. It's just text with a few special symbols.

### Example

**The Traindown source file**

```traindown
# Unit: lbs
# Unit for Kettlebell pullover: kg
# Unit for Plank: seconds
# Day: 20190919
# Time: 9am

* Felt beat up but the weights were pretty snappy
* Right hip is kinda grabby

Power Snatch: 95 2r 3s; 125 2r; 145 2s; 170 5s;
Power Clean: 135 3s; 185 2s; 205; 225; 245; 260 5s;
Clean Pull: 260 3s 3r;
BTNP: 95 6r; 135 6r; 165 3s 6r;
Squat: 365 3r 4s;
Row: 245 6r 3s;
Bench: 305 3r 4s;
One arm barbel curl: 3s 8r 55;
+ Kettlebell pullover: 20 3s 10r;
Plank: 30; 40; 35;
```

**Another example source file using the "pretty format"**
```traindown
# Unit: lbs
# Day: 20190920
# Time: 9am

Squat:
  135 5r;
  225 5r;
  315 5r;
  405 5r;
  455 5r 5s;

Press:
  135 5r;
  165 5r;
  190 5r 3s;
```

### Syntax

Below is the basic syntax for Traindown:
* **#** denotes a key/value pair of metadata. Could be anything.
* **&ast;** denotes a note. Current syntax supports only session level notes.
* Words followed by **:** denote the name of a movement.
* A number after a colon or semicolon is the load. If a number is followed by an **s** that marks a set count. **r** marks a rep count. You may omit either the s or the r (or both), which defaults to 1 for the value.
* **;** marks a change in load.
* A **+** denotes a super set (currently partially supported).

### TODO
- [x] Add support for linebreaks in movements
- [ ] Movement specific unit overrides--e.g., "Unit for" or some other means
- [ ] Better handling of supersets--i.e., more direct linkage between movements as well as validation
- [ ] Complete test suite
- [ ] Publish to Pub
- [ ] Stand up webpage
