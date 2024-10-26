---
title: "REX - Tiering Model"
description: "Comment déployer le tiering model pour sécuriser votre Active Directory"
tags: active-directory
listed: true
---

## Introduction

J'ai longtemps hésité à faire cet article, car il existe depuis maintenant quelques années de très bonnes ressources sur le sujet. Si vous voulez lire un article plus court et très complet (mais en anglais) sur le tiering model, je vous recommande vivement : [The Fundamentals of AD tiering — Improsec \| improving security](https://blog.improsec.com/tech-blog/the-fundamentals-of-ad-tiering).

L'idée derrière cet article est de partager mon retour d'expérience après avoir déployer ou aider au déploiement de plusieurs tiering model.

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'TIERING #' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>
