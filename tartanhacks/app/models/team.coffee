# @file team.coffee
# @brief Defines the Team database model.
# @author Oscar Bezi, oscar@bezi.io
# @since 7 January 2015
#===============================================================================

mongoose = require 'mongoose'
Schema = mongoose.Schema

TeamSchema = new Schema
    ownerID: String
    member2ID: String
    member3ID: String
    member4ID: String
    passphrase: String
    teamName: String
    teamNumber: Number

    hackName: String
    hackUrl: String
    hackDescription: String
    isSubmitted:
        type: Boolean
        default: false
    apis: String

module.exports = mongoose.model 'Team', TeamSchema
