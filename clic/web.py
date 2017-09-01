# -*- coding: utf-8 -*-
import os

# Hack HOME var so cheshire3 can make a useless config directory
os.environ['HOME'] = "/tmp"

from flask import Flask, request, Response, jsonify

app = Flask(__name__)

# ==== Metadata routes ====================================
import clic.c3

@app.route('/api/corpora', methods=['GET'])
def corpora():
    out = clic.c3.get_corpus_structure()
    return jsonify(dict(corpora=out))

# ==== Concordance routes =================================
import clic.concordance

@app.route('/api/concordance', methods=['GET'])
def concordances():
    out = clic.concordance.concordance(**request.args)
    return jsonify(dict(concordances=out))

# ==== Admin routes =======================================
import clic.c3chapter

@app.route('/api/warm/', methods=['GET'])
def concordance_warm():
    out = clic.c3chapter.warm_cache()
    return Response(out, mimetype='text/plain')


# ==== Error handlers =====================================
@app.errorhandler(404)
def handle_404(error):
    response = jsonify(dict(error=str(error)))
    response.status_code = 404
    return response

@app.errorhandler(500)
def handle_500(error):
    response = jsonify(dict(error=str(error)))
    response.status_code = 500
    return response

# ==== Application ========================================
def create_app():
    return app


if __name__ == '__main__':
    app = create_app()
    app.run(
        port=5000,
        debug=False,
    )
