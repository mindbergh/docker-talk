# @file teams.coffee
# @brief Implements the endpoints that handle teams at /teams
# @author Oscar Bezi, oscar@bezi.io
# @since 8 January 2015
#===============================================================================

module.exports = (app, models, auth) ->
    # POST /teams
    app.route '/teams'
        .post auth.requireLoggedIn, (req, res) ->
            team = new models.Team
                ownerID: req.session.userID
            team.save (err) ->
                if err?
                    models.err res, err
                else
                    res.status 200
                    res.end 'Team made'

    # POST /jointeam/:id
    app.route '/jointeam/:id'
        .post auth.requireLoggedIn, (req, res) ->
            models.Team.findOne
                    ownerID: req.params.id
                , (err, team) ->
                    if err?
                        models.err res, err
                    else
                        if team?
                            if req.session.userID in [team.ownerID, team.member2ID, team.member3ID, team.member4ID]
                                res.status 403
                                res.send 'Cannot join a team you\'re in'
                            else
                                if req.body.passphrase is team.passphrase and team.passphrase isnt ''
                                    done = () ->
                                        team.save (err) ->
                                            if err?
                                                models.err res, err
                                            else
                                                res.status 200
                                                res.end 'Joined team.'
                                    if team.member2ID?
                                        if team.member3ID?
                                            if team.member4ID?
                                                res.status 403
                                                res.end 'Team is full.'
                                            else
                                                team.member4ID = req.session.userID
                                                done()
                                        else
                                            team.member3ID = req.session.userID
                                            done()
                                    else
                                        team.member2ID = req.session.userID
                                        done()
                                else
                                    res.status 403
                                    res.end 'Incorrect passphrase'
                        else
                            res.status 404
                            res.end 'Team not found.'

    # GET /myteam
    app.route '/myteam'
        .get auth.requireLoggedIn, (req, res) ->
            models.Team.findOne
                    $or: [
                            ownerID: req.session.userID
                        ,
                            member2ID: req.session.userID
                        ,
                            member3ID: req.session.userID
                        ,
                            member4ID: req.session.userID
                    ]
                , (err, team) ->
                    if err?
                        models.err res, err
                    else
                        if team?
                            res.status 200
                            res.end JSON.stringify team
                        else
                            res.status 404
                            res.end 'Team not found.'

    # PUT /myteam
    app.route '/myteam'
        .post auth.requireLoggedIn, (req, res) ->
            models.Team.findOne
                    $or: [
                            ownerID: req.session.userID
                        ,
                            member2ID: req.session.userID
                        ,
                            member3ID: req.session.userID
                        ,
                            member4ID: req.session.userID
                    ]
                , (err, team) ->
                    if err?
                        models.err res, err
                    else
                        if team?
                            if req.body.passphrase?
                                team.passphrase = req.body.passphrase
                            if req.body.teamName?
                                team.teamName = req.body.teamName
                            if req.body.hackName?
                                team.hackName = req.body.hackName
                            if req.body.hackUrl?
                                team.hackUrl = req.body.hackUrl
                            if req.body.hackDescription?
                                team.hackDescription = req.body.hackDescription
                            if req.body.isSubmitted?
                                team.isSubmitted = req.body.isSubmitted
                            if req.body.apis?
                                team.apis = req.body.apis
                            team.save (err) ->
                                if err?
                                    models.err res, err
                                else
                                    res.status 200
                                    res.end 'User updated'
                        else
                            res.status 404
                            res.end 'Team not found.'

    # DELETE /myteam
    app.route '/myteam'
        .delete auth.requireLoggedIn, (req, res) ->
            models.Team.remove
                    $or: [
                            ownerID: req.session.userID
                        ,
                            member2ID: req.session.userID
                        ,
                            member3ID: req.session.userID
                        ,
                            member4ID: req.session.userID
                    ]
            , (err) ->
                if err?
                    models.err res, err
                else
                    res.status 200
                    res.end 'Team deleted.'

    # GET /teams
    app.route '/teams'
        .get auth.requireLoggedIn, (req, res) ->
            models.Team.find (err, teams) ->
                if err?
                    models.err res, err
                else
                    res.status 200
                    auth.isAdmin req, res, () ->
                        res.end JSON.stringify teams
                    , () ->
                        teams = teams.map (team) ->
                            delete team.passphrase
                            delete team.teamNumber
                        res.end JSON.stringify teams

    # GET /teams/:id
    app.route '/teams/:id'
        .get auth.requireAdmin, (req, res) ->
            models.Team.findOne
                    ownerID: req.params.id
                , (err, team) ->
                    if err?
                        models.err res, err
                    else
                        if team?
                            res.status 200
                            res.end JSON.stringify team
                        else
                            res.status 404
                            res.end 'User not found.'

    # PUT /teams/:id
    app.route '/teams/:id'
        .put auth.requireAdmin, (req, res) ->
            models.Team.findOne
                ownerID: req.params.id
            , (err, team) ->
                if err?
                    models.err res, err
                else
                    if team?
                        if req.body.passphrase?
                            team.passphrase = req.body.passphrase
                        if req.body.teamNumber?
                            team.teamNumber = req.body.teamNumber
                        if req.body.teamName?
                            team.teamName = req.body.teamName
                        if req.body.hackName?
                            team.hackName = req.body.hackName
                        if req.body.hackUrl?
                            team.hackUrl = req.body.hackUrl
                        if req.body.hackDescription?
                            team.hackDescription = req.body.hackDescription
                        if req.body.isSubmitted?
                            team.isSubmitted = req.body.isSubmitted
                        if req.body.apis?
                            team.apis = req.body.apis

    # DELETE /teams/:id
    app.route '/teams/:id'
        .delete auth.requireAdmin, (req, res) ->
            models.Team.findOneAndRemove
                    ownerID: req.params.id
                , (err, team) ->
                    if err?
                        models.err res, err
                    else
                        res.status 200
                        res.end JSON.stringify team
