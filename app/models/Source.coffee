
{Model} = require('spine')


class Source extends Model
  @configure 'Source', 'filename'
  
module.exports = Source