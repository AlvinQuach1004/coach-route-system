require 'pagy/extras/overflow'
require 'pagy/extras/metadata'
require 'pagy/extras/array'
require 'pagy/extras/countless'

Pagy::DEFAULT[:limit] = 10

Pagy::DEFAULT[:metadata] = %i[limit count page prev next last]
Pagy::DEFAULT[:overflow] = :last_page
